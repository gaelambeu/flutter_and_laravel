<?php

namespace App\Traits;

trait HasFactor
{
    public function calculateFactor()
    {
        if (!isset($this->price)) {
            return null;
        }

        return $this->price * 1.2;
    }
}
