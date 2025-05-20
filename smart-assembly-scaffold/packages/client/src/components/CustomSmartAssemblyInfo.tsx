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
        const response = await fetch(`${worldAPIURL}/types/`);
        const data = await response.json();
        
        // Ensure data is an array
        const itemsArray = Object.values(data);
        
        const items = await Promise.all(props?.inventory?.map(async item => {
          const itemInfo = itemsArray.find((d: any) => d.itemId === item.itemId);
          let alternativeItemInfo = itemsArray.find((d: any) => d.itemId === item?.itemObjectId);
          let imageUrl = '';
          console.log(itemInfo);
          if(itemInfo && itemInfo.attributes && itemInfo.attributes[0].value) {
            let itemTypeId = itemInfo.attributes[0].value.toString();
            const response = await fetch(`${worldAPIURL}/types/${itemTypeId}`);
            const data = await response.json();

            imageUrl = data.metadata.image || '';
          }
          return {
            name: itemInfo?.name || 'Unknown',
            quantity: Number(item.quantity),
            itemId: item.itemId || item.itemObjectId || 0,
            typeId: item.typeId || 0,
            imageUrl
          };
        }) || []);

        console.log(items);
        
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
              <img src={item.imageUrl} style={{width: '60px', height: '60px', borderRadius: '10px'}} alt={item.name} />
            ) : (
              <div style={{width: '60px', height: '60px', borderRadius: '10px', backgroundColor: '#2a2a2a', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'hsla(26, 85%, 58%, 1)', fontSize: '30px'}}>
                ?
              </div>
            )}
          </div>
        ))
      ) : (
        <div>No items in inventory</div>
      )}
    </div>
  )
}

const CustomSmartAssemblyInfo: React.FC<CustomSmartAssemblyInfoProps> = (props) => {
  console.log(props.assembly);
  return (
    <>
      <SmartAssemblyInfo {...props} />
      {props.assembly?.typeId === 77917 && (
        <div className="grid grid-cols-2 gap-0">
        <div>
          <div className="Quantum-Container Title">
            Inventory Items
          </div>
          <div className="Quantum-Container !py-4 !px-4">
            <EveScroll maxHeight="100px">
              <InventoryView inventory={props.assembly?.storage?.mainInventory?.items} />
            </EveScroll>
          </div>
        </div><div>
          <div className="Quantum-Container Title">
            Ephemeral Inventory Items
          </div>
          <div className="Quantum-Container !py-4 !px-4">
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