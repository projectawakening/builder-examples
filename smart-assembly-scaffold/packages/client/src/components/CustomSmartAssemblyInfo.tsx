import React, { useState, useEffect } from 'react';
import SmartAssemblyInfo from '@eveworld/ui-components/components/SmartAssemblyInfo';
import type { InventoryItem } from '@eveworld/types';
import EveScroll from '@eveworld/ui-components/components/EveScroll';
import EveLoadingAnimation from '@eveworld/ui-components/components/EveLoadingAnimation';

// Use the same props type as the original component
type CustomSmartAssemblyInfoProps = React.ComponentProps<typeof SmartAssemblyInfo> & {
  inventory?: any[];
};

type InventoryViewProps = {
  inventory: InventoryItem[];
  noItemsMessage?: string;
}

type ExtendedInventoryItem = InventoryItem & {
  imageUrl: string;
}

const InventoryView: React.FC<InventoryViewProps> = (props) => {
  const [inventoryItems, setInventoryItems] = useState<ExtendedInventoryItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const backupInventoryItems = props?.inventory?.map(item => {
      return {
        name: 'Unknown',
        quantity: item.quantity,
        itemId: item.itemId,
        typeId: item.typeId,
        imageUrl: '',
      };
    });

    const getAllInventoryItemInfo = async () => {
      if (!props.inventory) return;
      
      setIsLoading(true);
      const worldAPIURL = import.meta.env.VITE_WORLD_API_URL;

      if(!worldAPIURL) {
        setInventoryItems(backupInventoryItems || []);
        setIsLoading(false);
        return;
      }

      try {
        const items = await Promise.all(props?.inventory?.map(async item => {
          let itemTypeId = item.typeId;
          let itemName = '';
          let imageUrl = '';

          if(item.typeId) {
            const response = await fetch(`${worldAPIURL}/v2/types/${itemTypeId}`);

            const data = await response.json();

            itemName = data.name;
            imageUrl = data?.metadata?.image || '';
          }
          return {
            name: itemName || itemTypeId,
            quantity: Number(item.quantity),
            itemId: item.itemId || item.itemObjectId || 0,
            typeId: item.typeId || 0,
            imageUrl: imageUrl
          };
        }) || []);
        
        setInventoryItems(items);
      } catch (error) {
        console.error('Error fetching inventory items:', error);
        setInventoryItems(backupInventoryItems || []);
      } finally {
        setIsLoading(false);
      }
    };

    getAllInventoryItemInfo();
  }, [props.inventory]);

  return (
    <div>
      {isLoading ? (
        <EveLoadingAnimation position="horizontal">
          <div className="h-20" />
        </EveLoadingAnimation>
      ) : inventoryItems.length > 0 ? (
        inventoryItems.map((item: InventoryItem) => (
          <div className="text-xs flex items-center justify-between" key={item.itemId}>
            <div>{item.name} <b>(X {item.quantity})</b></div>
            {item.imageUrl ? (
              <img src={item.imageUrl} className="item-icon" alt={item.name} />
            ) : (
              <div className="item-icon item-empty">
                ?
              </div>
            )}
          </div>
        ))
      ) : (
        <div className="text-xs flex items-center justify-between">{props.noItemsMessage || "No items in inventory"}</div>
      )}
    </div>
  )
}

const CustomSmartAssemblyInfo: React.FC<CustomSmartAssemblyInfoProps> = (props) => {
  return (
    <>
      <SmartAssemblyInfo {...props} />
      {props.assembly?.smartAssemblyType == "SSU" && (
        <div className="grid grid-cols-2 gap-0">
          <div>
            <div className="Quantum-Container Title">
              Inventory Items
            </div>
            <div className="Quantum-Container !py-4 !px-4 inventory-container">
              <EveScroll maxHeight="100px">
                <InventoryView inventory={props.assembly?.storage?.mainInventory?.items} />
              </EveScroll>
            </div>
          </div>
          <div>
            <div className="Quantum-Container Title">
              Ephemeral Inventory Items
            </div>
            <div className="Quantum-Container !py-4 !px-4 inventory-container">
              <EveScroll maxHeight="100px">
                <InventoryView noItemsMessage="No items in your ephemeral inventory" inventory={props.assembly?.storage?.ephemeralInventories[0]?.ephemeralInventoryItems} />
              </EveScroll>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default CustomSmartAssemblyInfo; 