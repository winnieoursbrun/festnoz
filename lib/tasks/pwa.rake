require "fileutils"
require "net/http"
require "open3"
require "shellwords"
require "timeout"
require "uri"

namespace :pwa do
  desc "Generate PWA screenshots (mobile + desktop) with Playwright"
  task screenshot: :environment do
    base_url = ENV.fetch("PWA_SCREENSHOT_BASE_URL", ENV.fetch("URL", "http://127.0.0.1:3000"))
    path = ENV.fetch("PWA_SCREENSHOT_PATH", "/")
    target_url = URI.join("#{base_url}/", path.sub(%r{\A/}, "")).to_s
    login_url = URI.join("#{base_url}/", "api/auth/login").to_s

    output_dir = Rails.root.join("public", "images", "pwa")
    mobile_output = output_dir.join("screenshot-mobile.png")
    desktop_output = output_dir.join("screenshot-desktop.png")
    script_path = Rails.root.join("tmp", "pwa_screenshot.cjs")
    server_pid = nil

    FileUtils.mkdir_p(output_dir)
    server_pid = ensure_base_url_available!(base_url)

    File.write(script_path, playwright_script_content)

    puts "[pwa:screenshot] Generating authenticated screenshots from #{target_url}"
    run_command!(
      {
        "PWA_BASE_URL" => base_url,
        "PWA_LOGIN_URL" => login_url,
        "PWA_TARGET_URL" => target_url,
        "PWA_EMAIL" => ENV.fetch("PWA_SCREENSHOT_EMAIL", "user@example.com"),
        "PWA_PASSWORD" => ENV.fetch("PWA_SCREENSHOT_PASSWORD", "password"),
        "PWA_WAIT_SELECTOR" => ENV.fetch("PWA_SCREENSHOT_WAIT_SELECTOR", "#app"),
        "PWA_WAIT_MS" => ENV.fetch("PWA_SCREENSHOT_WAIT_MS", "2500"),
        "PWA_MOBILE_OUTPUT" => mobile_output.to_s,
        "PWA_DESKTOP_OUTPUT" => desktop_output.to_s
      },
      "npx", "--yes", "-p", "playwright@1.53.2", "-c", "node #{Shellwords.escape(script_path.to_s)}"
    )

    puts "[pwa:screenshot] Done"
    puts "  - #{mobile_output}"
    puts "  - #{desktop_output}"
  ensure
    stop_server(server_pid) if server_pid
  end

  def run_command!(*command)
    env = command.first.is_a?(Hash) ? command.shift : {}
    stdout, stderr, status = Open3.capture3(env, *command, chdir: Rails.root.to_s)

    puts stdout if stdout.present?
    return if status.success?

    warn stderr
    raise "Command failed: #{command.join(' ')}"
  end

  def ensure_base_url_available!(base_url)
    base_uri = URI(base_url)
    return nil if url_reachable?(base_uri)

    unless local_host?(base_uri.host)
      raise "Base URL not reachable: #{base_url}. Start your app and retry."
    end

    host = base_uri.host
    port = base_uri.port
    log_file = Rails.root.join("log", "pwa_screenshot_server.log")

    puts "[pwa:screenshot] Base URL unreachable, starting temporary Rails server on #{host}:#{port}"
    pid = Process.spawn(
      { "RAILS_ENV" => ENV.fetch("RAILS_ENV", "development") },
      "bundle", "exec", "rails", "server", "-b", host, "-p", port.to_s,
      chdir: Rails.root.to_s,
      out: log_file.to_s,
      err: :out
    )

    deadline = Time.now + 60
    until url_reachable?(base_uri)
      if Time.now > deadline
        stop_server(pid)
        raise "Could not start Rails server at #{base_url}. Check #{log_file}."
      end

      sleep 1
    end

    pid
  end

  def url_reachable?(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    response = http.request(Net::HTTP::Get.new(uri.request_uri.presence || "/"))
    response.code.to_i.positive?
  rescue StandardError
    false
  end

  def local_host?(host)
    [ "127.0.0.1", "localhost", "::1" ].include?(host)
  end

  def stop_server(pid)
    Process.kill("TERM", pid)
    Timeout.timeout(10) do
      Process.wait(pid)
    end
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  rescue Timeout::Error
    Process.kill("KILL", pid)
    nil
  end

  def playwright_script_content
    <<~JS
      const { chromium } = require('playwright');

      const loginUrl = process.env.PWA_LOGIN_URL;
      const targetUrl = process.env.PWA_TARGET_URL;
      const email = process.env.PWA_EMAIL;
      const password = process.env.PWA_PASSWORD;
      const waitSelector = process.env.PWA_WAIT_SELECTOR || '#app';
      const waitMs = Number(process.env.PWA_WAIT_MS || '2500');
      const mobileOutput = process.env.PWA_MOBILE_OUTPUT;
      const desktopOutput = process.env.PWA_DESKTOP_OUTPUT;

      async function login(page) {
        await page.goto(loginUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });

        const emailInput = page.locator('input[name="user[email]"], input[type="email"]').first();
        const passwordInput = page.locator('input[name="user[password]"], input[type="password"]').first();
        const submitButton = page.locator('button[type="submit"], input[type="submit"]').first();

        await emailInput.waitFor({ state: 'visible', timeout: 15000 });
        await passwordInput.waitFor({ state: 'visible', timeout: 15000 });

        await emailInput.fill(email);
        await passwordInput.fill(password);

        await Promise.all([
          page.waitForNavigation({ waitUntil: 'networkidle', timeout: 30000 }).catch(() => null),
          submitButton.click()
        ]);
      }

      async function capture(viewport, outputPath) {
        const browser = await chromium.launch({ headless: true });
        const context = await browser.newContext({ viewport });
        const page = await context.newPage();

        await login(page);
        await page.goto(targetUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
        await page.waitForLoadState('networkidle', { timeout: 30000 });

        if (waitSelector) {
          await page.locator(waitSelector).first().waitFor({ state: 'visible', timeout: 30000 });
        }

        if (waitMs > 0) {
          await page.waitForTimeout(waitMs);
        }

        await page.screenshot({ path: outputPath, fullPage: true });
        await browser.close();
      }

      (async () => {
        await capture({ width: 390, height: 844 }, mobileOutput);
        await capture({ width: 1365, height: 768 }, desktopOutput);
      })().catch((error) => {
        console.error(error);
        process.exit(1);
      });
    JS
  end
end
