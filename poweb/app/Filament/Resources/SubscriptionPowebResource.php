<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubscriptionPowebResource\Pages;
use App\Filament\Resources\SubscriptionPowebResource\RelationManagers;
use App\Models\Subscription;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Actions\Action;



class SubscriptionPowebResource extends Resource
{
    protected static ?string $model = Subscription::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('google_id')->required(),
            Forms\Components\TextInput::make('prix')->numeric()->default(100),
            Forms\Components\Select::make('status')
                ->options(['pay' => 'Pay', 'nopay' => 'No Pay']),
            Forms\Components\Select::make('account')
                ->options(['unlocked' => 'Unlocked', 'locked' => 'Locked']),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            Tables\Columns\TextColumn::make('email'),
            Tables\Columns\TextColumn::make('google_id'),
            Tables\Columns\TextColumn::make('prix'),
            Tables\Columns\TextColumn::make('jours'),
            Tables\Columns\TextColumn::make('expire_date'),
            Tables\Columns\BadgeColumn::make('status')->colors(['pay' => 'success', 'nopay' => 'danger']),
            Tables\Columns\BadgeColumn::make('account')->colors(['unlocked' => 'success', 'locked' => 'danger']),
        ])->actions([
            Tables\Actions\EditAction::make(),
            Action::make('lockedAccount')
                ->label('🔒 Lock Account')
                ->action(fn (Subscription $record) => $record->update(['account' => 'locked']))
                ->visible(fn (Subscription $record) => $record->account === 'unlocked'),

            Action::make('unlockedAccount')
            ->label('🔓 Unlock Account')
            ->action(fn (Subscription $record) => $record->update(['account' => 'unlocked']))
            ->visible(fn (Subscription $record) => $record->account === 'locked'),
        ])
            ->filters([
                //
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSubscriptionPowebs::route('/'),
            'create' => Pages\CreateSubscriptionPoweb::route('/create'),
            'edit' => Pages\EditSubscriptionPoweb::route('/{record}/edit'),
        ];
    }
}
