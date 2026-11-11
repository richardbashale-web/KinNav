import {
  Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post, Query, Req, UseGuards,
} from '@nestjs/common';
import { IsIn, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';
import type { Request } from 'express';
import { JwtGuard } from './auth.guard';
import { UsersService, type UserProfilePatch } from './users.service';

class ProfilePatch implements UserProfilePatch {
  @IsOptional()
  @IsString()
  display_name?: string;
}

class FavoriteCreate {
  @IsString()
  name!: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  lat!: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  lng!: number;

  @IsOptional()
  @IsString()
  address?: string;

  @IsIn(['home', 'work', 'other'])
  type!: 'home' | 'work' | 'other';
}

type AuthenticatedRequest = Request & { userId: string };

@Controller('me')
@UseGuards(JwtGuard)
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get()
  getMe(@Req() request: AuthenticatedRequest) {
    return this.users.getProfile(request.userId);
  }

  @Patch()
  updateMe(@Req() request: AuthenticatedRequest, @Body() body: ProfilePatch) {
    return this.users.updateProfile(request.userId, body);
  }

  @Get('history')
  history(
    @Req() request: AuthenticatedRequest,
    @Query('page', new ParseIntPipe({ optional: true })) page = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit = 20,
  ) {
    return this.users.history(request.userId, Math.max(1, page), Math.min(100, Math.max(1, limit)));
  }

  @Post('favorites')
  addFavorite(@Req() request: AuthenticatedRequest, @Body() body: FavoriteCreate) {
    return this.users.addFavorite(request.userId, body);
  }

  @Delete('favorites/:id')
  removeFavorite(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    this.users.removeFavorite(request.userId, id);
    return { status: 'deleted' };
  }
}
