import React from "react";
import { EveButton } from "@eveworld/ui-components";

interface ItemMetadata{
  name: string,
  image: string,
  smartObjectId: string
}

const ItemSearchResult = React.memo(
  ({
    item,
    selectFunction
  }: {
    item: ItemMetadata,
    selectFunction: () => void
  }) => {
    return (
      <div className="grid grid-cols-2 item-grid">
        <div className="item-preview">
          <div className="item-inline">
            <h1>{item.name}</h1>
          </div>
        </div>
        <EveButton typeClass="primary" onClick={selectFunction} disabled={false}>
          Select Item
        </EveButton>
      </div>    
    )
});

export default React.memo(ItemSearchResult);