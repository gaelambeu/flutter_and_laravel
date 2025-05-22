<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Enregistrement des commandes Artisan personnalisées.
     */
    protected $commands = [
        Commands\DecrementSubscriptionDays::class,
    ];

    /**
     * Définition des tâches planifiées.
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command('subscription:decrement')->daily();
    }

    /**
     * Enregistrement des fichiers de commande automatiquement.
     */
    protected function commands()
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
