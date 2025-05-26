<?php

namespace App\Observers;

use App\Models\User;
use App\Models\Subscription;

class UserObserver
{
    /**
     * Handle the User "created" event.
     */
    public function created(User $user)
    {
        Subscription::firstOrCreate(
            ['google_id' => $user->google_id],
            [
                'prix' => 100,
                'status' => 'pay',
                'account' => 'unlocked',
                'jours' => 30,
                'type_account' => 'new',
            ]
        );
    }

    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
        //
    }

    /**
     * Handle the User "deleted" event.
     */
    public function deleted(User $user): void
    {
        //
    }

    /**
     * Handle the User "restored" event.
     */
    public function restored(User $user): void
    {
        //
    }

    /**
     * Handle the User "force deleted" event.
     */
    public function forceDeleted(User $user): void
    {
        //
    }
}
