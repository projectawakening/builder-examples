import React, { useState, useEffect } from 'react';
import SmartAssemblyInfo from '@eveworld/ui-components/components/SmartAssemblyInfo';
import type { SmartAssemblyType, SmartAssemblies, SmartCharacter, ChainConfig, InventoryItem } from '@eveworld/types';
import type { GatewayNetworkConfig } from '@eveworld/utils';
import EveScroll from '@eveworld/ui-components/components/EveScroll';
import EveLoadingAnimation from '@eveworld/ui-components/components/EveLoadingAnimation';

// Use the same props type as the original component
type CustomSmartAssemblyInfoProps = React.ComponentProps<typeof SmartAssemblyInfo> & {
  inventory?: any[];
};

type InventoryViewProps = {
  inventory: InventoryItem[];
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
          let imageUrl = '';
          let itemTypeId = item.typeId;
          let itemName = item.name;

          if(item.typeId) {
            const response = await fetch(`${worldAPIURL}/v2/types/${item.typeId}`);

            const data = await response.json();

            imageUrl = data?.metadata?.image || '';
            itemName = data.name;
          }
          return {
            name: itemName || item.typeId,
            quantity: Number(item.quantity),
            itemId: item.itemId || item.itemObjectId || 0,
            typeId: item.typeId || 0,
            imageUrl
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
              <img src={item.imageUrl} style={{width: '40px', height: '40px', borderRadius: '10px'}} alt={item.name} />
            ) : (
              <div style={{width: '40px', height: '40px', borderRadius: '10px', backgroundColor: 'transparent', border: '0.5px solid hsla(26, 85%, 58%, 1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'hsla(26, 85%, 58%, 1)', fontSize: '20px'}}>
                ?
              </div>
            )}
          </div>
        ))
      ) : (
        <div className="text-xs flex items-center justify-between">No items in inventory</div>
      )}
    </div>
  )
}

const CustomSmartAssemblyInfo: React.FC<CustomSmartAssemblyInfoProps> = (props) => {
  return (
    <>
      <SmartAssemblyInfo {...props} />
      {props.assembly?.typeId === 77917 && (
        <div className="grid grid-cols-2 gap-0">
        <div>
          <div className="Quantum-Container Title">
            Inventory Items
          </div>
          <div className="Quantum-Container !py-4 !px-4" style={{minHeight: '100px', maxHeight: '100px'}}>
            <EveScroll maxHeight="100px">
              <InventoryView inventory={props.assembly?.storage?.mainInventory?.items} />
            </EveScroll>
          </div>
        </div><div>
          <div className="Quantum-Container Title">
            Ephemeral Inventory Items
          </div>
          <div className="Quantum-Container !py-4 !px-4" style={{minHeight: '100px', maxHeight: '100px'}}>
            <EveScroll maxHeight="100px">
              <InventoryView inventory={props.assembly?.storage?.ephemeralInventories[0]?.ephemeralInventoryItems} />
            </EveScroll>
          </div>
        </div>
        </div>
      )}
    </>
  );
};

export default CustomSmartAssemblyInfo; 