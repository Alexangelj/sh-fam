import { BigNumber } from "@ethersproject/bignumber"
import { parseEther } from "@ethersproject/units"

/**
 * @notice Mapping of currencyIds to their string names
 */
export const CURRENCY_IDS: { [currencyId: number]: string } = {
  2: "MOD_FOUR",
  3: "MOD_TWO",
  4: "ADD_TWO",
  5: "ADD_FOUR",
  6: "REMOVE",
  7: "AUGMENT_TWO",
  8: "AUGMENT_FOUR",
  9: "MEM_COPY",
}

/**
 * @notice Mapping of costs to use currency type, in void tokens
 */
export const CURRENCY_COSTS: { [currencyId: number]: BigNumber } = {
  2: parseEther("50"),
  3: parseEther("15"),
  4: parseEther("10"),
  5: parseEther("35"),
  6: parseEther("20"),
  7: parseEther("5"),
  8: parseEther("100"),
  9: parseEther("10000"),
}

/**
 * @notice Mapping of nft addresses to base costs
 */
export const BASE_COSTS: { [token: string]: BigNumber } = {
  ["0xA7206d878c5c3871826DfdB42191c49B1D11F466"]: parseEther("100"),
}

/**
 * @notice Mapping of token addresses with specific ids to premium costs
 */
export const PREMIUM_COSTS: { [token: string]: { [id: string]: BigNumber } } = {
  ["0xA7206d878c5c3871826DfdB42191c49B1D11F466"]: { [0]: parseEther("1") },
}
