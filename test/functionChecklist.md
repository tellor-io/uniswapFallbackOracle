# Function Checklist

## Overview

The fallback oracle tests a couple of different conditions and determines whether or not to fall back to Tellor. User is able to determine the levers for what these boundaries are. Thus…

### Liquidity
* Uniswap < User-Defined → Uniswap
* Uniswap = User-Defined → Might still need to determine the best outcome here: probably just say if greater than, so Tellor
* Uniswap > User-Defined → Tellor

### Data Freshness
* Uniswap timestamp is within Tellor timestamp by given value → Uniswap
* Uniswap timestamp is equal to Tellor timestamp → Tellor
* Uniswap timestamp is farther from Tellor timestamp than given value → Tellor
* Not sure: should I just default on who is earlier? I guess it depends on the user? I guess this would just be a lever of 0?

### Value within Threshold
* Uniswap value is within Tellor value by given percentage → Uniswap
* Uniswap value is equal to Tellor value → Tellor
* Uniswap is father from Tellor value by given percentage → Tellor

## Considerations:

* What happens when the two values are equal to each other? Default to Tellor, or let the user choose?
* Should we let the user choose which operations take precedence? Maybe data freshness is more important to them than liquidity? Or maybe they just care if the values are close enough?

In either case, the main question is: how do we let them choose this precedence?
