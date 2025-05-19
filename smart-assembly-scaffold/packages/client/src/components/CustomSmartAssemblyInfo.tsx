import React, { useState, useEffect } from 'react';
import SmartAssemblyInfo from '@eveworld/ui-components/components/SmartAssemblyInfo';
import type { SmartAssemblyType, SmartAssemblies, SmartCharacter, ChainConfig } from '@eveworld/types';
import type { GatewayNetworkConfig } from '@eveworld/utils';
import EveScroll from '@eveworld/ui-components/components/EveScroll';

// Use the same props type as the original component
type CustomSmartAssemblyInfoProps = React.ComponentProps<typeof SmartAssemblyInfo> & {
  inventory?: any[];
};

const CustomSmartAssemblyInfo: React.FC<CustomSmartAssemblyInfoProps> = (props) => {
  const [inventoryItems, setInventoryItems] = useState<any[]>([]);

  useEffect(() => {
    const backupInventoryItems = props?.inventory?.map(item => {
      return {
        name: 'Unknown',
        quantity: item.quantity,
        itemId: item.itemId,
        typeId: item.typeId,
      };
    });

    const getAllInventoryItemInfo = async () => {
      if (!props.inventory) return;
      
      const worldAPIURL = import.meta.env.VITE_WORLD_API_URL;

      if(!worldAPIURL) {
        setInventoryItems(backupInventoryItems || []);
        return;
      }

      try {
        const response = await fetch(`${worldAPIURL}/types/`);
        const data = await response.json();
        
        // Ensure data is an array
        const itemsArray = Object.values(data);
        
        const items = props?.inventory?.map(item => {
          const itemInfo = itemsArray.find((d: any) => d.itemId === item.itemId);
          return {
            name: itemInfo?.name || 'Unknown',
            quantity: item.quantity,
            itemId: item.itemId,
            typeId: item.typeId,
          };
        });
        
        setInventoryItems(items);
      } catch (error) {
        console.error('Error fetching inventory items:', error);
        setInventoryItems(backupInventoryItems || []);
      }
    };

    getAllInventoryItemInfo();
  }, [props.inventory]);

  return (
    <>
      <SmartAssemblyInfo {...props} />
      {props.assembly?.typeId === 77917 && (
        <>
          <div className="Quantum-Container Title">
            Inventory Items
          </div>
          <div className="Quantum-Container !py-4 !px-4 grid grid-cols-2 gap-4">
            <EveScroll maxHeight="100px">
            {inventoryItems.length > 0 ? (
              inventoryItems.map((item: any) => (
                <div className="text-xs" key={item.itemId}>
                  {item.name} (x {item.quantity})
                </div>
              ))
            ) : (
              <div>No items in inventory</div>
            )}
            </EveScroll>
          </div>
        </>
      )}
    </>
  );
};

export default CustomSmartAssemblyInfo; 