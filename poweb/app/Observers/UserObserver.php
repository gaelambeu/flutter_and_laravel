<?php

namespace App\Observers;

use App\Models\User;
use App\Models\Subscription;

class UserObserver
{
    public function created(User $user)
    {
        if (!$user->google_id) return;

        $subscription = Subscription::firstOrCreate(
            [
                'google_id' => $user->google_id,
                'email' => $user->email,
            ],
            [
                'prix' => 100,
                'status' => 'pay',
                'account' => 'unlocked',
                'expire_date' => now(),
                'type_account' => 'new',
            ]
        );

        $subscription->updateSubscription(30); // Ajoute 30 jours et enregistre jours restants
    }

    public function updated(User $user): void {}
    public function deleted(User $user): void {}
    public function restored(User $user): void {}
    public function forceDeleted(User $user): void {}
}
