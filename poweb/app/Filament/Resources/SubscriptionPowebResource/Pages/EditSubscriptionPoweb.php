<?php

namespace App\Filament\Resources\SubscriptionPowebResource\Pages;

use App\Filament\Resources\SubscriptionPowebResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSubscriptionPoweb extends EditRecord
{
    protected static string $resource = SubscriptionPowebResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
