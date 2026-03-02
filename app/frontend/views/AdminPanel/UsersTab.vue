<template>
  <div v-motion-fade-up>
    <Card class="bg-card/50 border-border/50">
      <CardHeader>
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Users class="w-5 h-5 text-blue-500" />
              Users
            </CardTitle>
            <CardDescription class="mt-1">
              {{ usersStore.users.length }} users registered
            </CardDescription>
          </div>
          <Button @click="$emit('edit-user', null)" class="font-medium">
            <Plus class="w-4 h-4 mr-2" />
            Add User
          </Button>
        </div>
      </CardHeader>
      <CardContent>
        <!-- Loading State -->
        <div v-if="usersStore.loading" class="space-y-4">
          <div v-for="i in 5" :key="i" class="flex items-center gap-4 p-4 rounded-lg bg-background/50">
            <Skeleton class="w-10 h-10 rounded-full" />
            <div class="flex-1 space-y-2">
              <Skeleton class="h-4 w-1/3" />
              <Skeleton class="h-3 w-1/4" />
            </div>
          </div>
        </div>

        <!-- Table -->
        <div v-else class="rounded-lg border border-border/50 overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow class="bg-muted/30 hover:bg-muted/30">
                <TableHead>User</TableHead>
                <TableHead>Email</TableHead>
                <TableHead class="text-center">Role</TableHead>
                <TableHead class="text-center">Provider</TableHead>
                <TableHead class="text-center">Following</TableHead>
                <TableHead class="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="user in usersStore.users"
                :key="user.id"
                class="hover:bg-accent/50 transition-colors"
              >
                <TableCell>
                  <div class="flex items-center gap-3">
                    <Avatar class="h-10 w-10 ring-2 ring-border/50">
                      <AvatarFallback class="bg-blue-500/10 text-blue-500">
                        {{ user.username.charAt(0).toUpperCase() }}
                      </AvatarFallback>
                    </Avatar>
                    <span class="font-medium">{{ user.username }}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <span class="text-muted-foreground">{{ user.email }}</span>
                </TableCell>
                <TableCell class="text-center">
                  <Badge v-if="user.admin" variant="default" class="bg-amber-500/10 text-amber-400 border-amber-500/20">
                    <Shield class="w-3 h-3 mr-1" />
                    Admin
                  </Badge>
                  <Badge v-else variant="secondary">
                    User
                  </Badge>
                </TableCell>
                <TableCell class="text-center">
                  <span class="text-sm">{{ user.provider || 'Email' }}</span>
                </TableCell>
                <TableCell class="text-center">
                  <span class="font-medium">{{ user.followed_artists_count || 0 }}</span>
                </TableCell>
                <TableCell class="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger as-child>
                      <Button variant="ghost" size="sm" class="h-8 w-8 p-0">
                        <MoreHorizontal class="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" class="w-40">
                      <DropdownMenuItem @click="$emit('edit-user', user)" class="cursor-pointer">
                        <Pencil class="w-4 h-4 mr-2" />
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem @click="$emit('delete-user', user)" class="cursor-pointer text-destructive focus:text-destructive">
                        <Trash2 class="w-4 h-4 mr-2" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import { useUsersStore } from '../../stores/users'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Skeleton } from '@/components/ui/skeleton'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Users, Shield, Plus, MoreHorizontal, Pencil, Trash2 } from 'lucide-vue-next'

defineEmits<{
  'edit-user': [user: any]
  'delete-user': [user: any]
}>()

const usersStore = useUsersStore()
</script>
