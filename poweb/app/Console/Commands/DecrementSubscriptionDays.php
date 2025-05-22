<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Subscription;

class DecrementSubscriptionDays extends Command
{
    protected $signature = 'subscription:decrement';
    protected $description = 'Décrémente les jours d’abonnement et bloque les comptes expirés';

    public function handle()
    {
        $subscriptions = Subscription::all();

        foreach ($subscriptions as $sub) {
            if ($sub->jours > 0) {
                $sub->jours -= 1;

                if ($sub->jours === 0) {
                    $sub->account = 'locked';
                }

                $sub->save();
            }
        }

        $this->info('Jours décrémentés et comptes mis à jour.');
    }
}
