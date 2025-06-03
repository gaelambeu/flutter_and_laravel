<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Subscription;
use Carbon\Carbon;

class UpdateSubscriptionDays extends Command
{
    protected $signature = 'subscriptions:update-days';
    protected $description = 'Met à jour le nombre de jours restants pour tous les abonnements';

    public function handle()
    {
        $subscriptions = Subscription::all();

        foreach ($subscriptions as $subscription) {
            if ($subscription->expire_date) {
                $subscription->jours = Carbon::now()->diffInDays($subscription->expire_date, false);
                $subscription->save();
            }
        }

        $this->info('Jours restants mis à jour.');
    }
}
