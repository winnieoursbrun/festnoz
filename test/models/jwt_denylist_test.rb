# frozen_string_literal: true

require "test_helper"

class JwtDenylistTest < ActiveSupport::TestCase
  it "can be created with jti and exp" do
    denylist = build(:jwt_denylist)
    assert denylist.valid?
  end

  it "can be created with a nil jti (no model-level validation)" do
    denylist = build(:jwt_denylist, jti: nil)
    assert denylist.valid?
  end

  it "persists to the database via create!" do
    denylist = create(:jwt_denylist)
    assert denylist.persisted?
  end
end
