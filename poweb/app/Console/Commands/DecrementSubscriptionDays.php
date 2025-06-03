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

        foreach (Subscription::all() as $sub) {
            if ($sub->jours > 0) {
                $sub->jours -= 1;

                if ($sub->jours === 0) {
                    $sub->status = 'nopay';
                    $sub->account = 'locked';

                    // ✅ C’est ici que type_account devient "old"
                    if ($sub->type_account === 'new') {
                        $sub->type_account = 'old';
                    }
                }

                $sub->save();
            }
        }


        $this->info('Jours décrémentés et comptes mis à jour.');
    }
}
