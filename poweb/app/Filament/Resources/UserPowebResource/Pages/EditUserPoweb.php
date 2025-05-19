<?php

namespace App\Filament\Resources\UserPowebResource\Pages;

use App\Filament\Resources\UserPowebResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditUserPoweb extends EditRecord
{
    protected static string $resource = UserPowebResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
