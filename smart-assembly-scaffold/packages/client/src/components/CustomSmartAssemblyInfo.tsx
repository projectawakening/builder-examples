import React, { useState, useEffect, useMemo } from "react";
import SmartAssemblyInfo from "@eveworld/ui-components/components/SmartAssemblyInfo";
import type { InventoryItem } from "@eveworld/types";
import EveScroll from "@eveworld/ui-components/components/EveScroll";
import EveLoadingAnimation from "@eveworld/ui-components/components/EveLoadingAnimation";

// Use the same props type as the original component
type CustomSmartAssemblyInfoProps = React.ComponentProps<
  typeof SmartAssemblyInfo
> & {
  inventory?: any[];
  assembly?: {
    smartAssemblyType?: string;
    inventory?: {
      storageItems?: InventoryItem[];
      ephemeralInventoryList?: Array<{
        ephemeralInventoryItems?: InventoryItem[];
      }>;
    };
  };
};

type InventoryViewProps = {
  inventory: InventoryItem[];
  noItemsMessage?: string;
};

type ExtendedInventoryItem = InventoryItem & {
  imageUrl: string;
};

// Cache for item data to prevent re-fetching
const itemCache = new Map<number, { name: string; imageUrl: string }>();

const InventoryView: React.FC<InventoryViewProps> = (props) => {
  const [inventoryItems, setInventoryItems] = useState<ExtendedInventoryItem[]>(
    []
  );
  
  const [isInitialLoad, setIsInitialLoad] = useState(true);

  // Create a stable key for the inventory to detect actual changes
  const inventoryKey = useMemo(() => {
    if (!props.inventory) return "";
    return props.inventory
      .map(item => `${item.typeId}-${item.quantity}-${item.itemId}`)
      .sort()
      .join("|");
  }, [props.inventory]);

  useEffect(() => {
    const backupInventoryItems = props?.inventory?.map((item) => {
      return {
        name: "Unknown",
        quantity: item.quantity,
        itemId: item.itemId,
        typeId: item.typeId,
        imageUrl: "",
      };
    });

    const getAllInventoryItemInfo = async () => {
      if (!props.inventory) {
        setInventoryItems([]);
        setIsInitialLoad(false);
        return;
      }

      const worldAPIURL = import.meta.env.VITE_WORLD_API_URL;
      if (!worldAPIURL) {
        setInventoryItems(backupInventoryItems || []);
        setIsInitialLoad(false);
        return;
      }

      try {
        const items = await Promise.all(
          props?.inventory?.map(async (item) => {
            let itemTypeId = item.typeId;
            let itemName = "";
            let imageUrl = "";

            // Check cache first
            if (itemCache.has(itemTypeId)) {
              const cached = itemCache.get(itemTypeId)!;
              itemName = cached.name;
              imageUrl = cached.imageUrl;
            } else if (item.typeId) {
              const response = await fetch(
                `${worldAPIURL}/v2/types/${itemTypeId}`
              );

              const data = await response.json();

              itemName = data.name;
              imageUrl = data?.metadata?.image || "";
              
              // Cache the result
              itemCache.set(itemTypeId, { name: itemName, imageUrl });
            }
            
            return {
              name: itemName || String(itemTypeId),
              quantity: Number(item.quantity),
              itemId: item.itemId || 0,
              typeId: item.typeId || 0,
              imageUrl: imageUrl,
            };
          }) || []
        );

        setInventoryItems(items);
      } catch (error) {
        console.error("Error fetching inventory items:", error);
        setInventoryItems(backupInventoryItems || []);
      } finally {
        setIsInitialLoad(false);
      }
    };

    getAllInventoryItemInfo();
  }, [inventoryKey]);

  return (
    <div>
      {isInitialLoad ? (
        <EveLoadingAnimation position="horizontal">
          <div className="h-20" />
        </EveLoadingAnimation>
      ) : inventoryItems.length > 0 ? (
        inventoryItems.map((item: ExtendedInventoryItem) => (
          <div
            className="text-xs flex items-center justify-between"
            key={item.itemId}
          >
            <div>
              {item.name} <b>(X {item.quantity})</b>
            </div>
            {item.imageUrl ? (
              <img src={item.imageUrl} className="item-icon" alt={item.name} />
            ) : (
              <div className="item-icon item-empty">?</div>
            )}
          </div>
        ))
      ) : (
        <div className="text-xs flex items-center justify-between">
          {props.noItemsMessage || "No items in inventory"}
        </div>
      )}
    </div>
  );
};

// This is an example of how to extend the Smart Assembly Scaffold
const CustomSmartAssemblyInfo: React.FC<CustomSmartAssemblyInfoProps> = (
  props
) => {
  return (
    <>
      <SmartAssemblyInfo {...props} />
      {props.assembly?.smartAssemblyType == "SSU" && (
        <div className="grid grid-cols-2 gap-0">
          <div>
            <div className="Quantum-Container Title">Inventory Items</div>
            <div className="Quantum-Container !py-4 !px-4 inventory-container">
              <EveScroll maxHeight="100px">
                <InventoryView
                  inventory={props.assembly?.inventory?.storageItems || []}
                />
              </EveScroll>
            </div>
          </div>
          <div>
            <div className="Quantum-Container Title">
              Ephemeral Inventory Items
            </div>
            <div className="Quantum-Container !py-4 !px-4 inventory-container">
              <EveScroll maxHeight="100px">
                <InventoryView
                  noItemsMessage="No items in your ephemeral inventory"
                  inventory={
                    props.assembly?.inventory?.ephemeralInventoryList?.[0]
                      ?.ephemeralInventoryItems || []
                  }
                />
              </EveScroll>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default CustomSmartAssemblyInfo;
