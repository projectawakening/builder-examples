import { createStash } from "@latticexyz/stash/internal";
import config from "contracts/mud.config";
import worldConfig from "contracts/eveworld/mud.config";

const combinedConfig = {
    namespaces: {
        ...worldConfig.namespaces,
        ...config.namespaces
    }
}

export const stash = createStash(combinedConfig);