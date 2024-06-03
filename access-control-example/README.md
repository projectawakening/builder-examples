# Access Control Examples 

Included are two example implementations of a simple Access Control to protect you custom EVE World Systems:

- [AccessControlHook](./access-control-hook) - implements a hook based pattern implementation for access control. The benefits of hook implementations are: (i) they individual target single entities in the EVE World, (ii) they can be applied after contract deployment, and (iii) they can be removed and re-applied as needed
- [AccessControl](./access-control-standard) = implements a inherit/modifier pattern implmentation. The benefit of this standard approach are simplicity. The trade-off is that it is `hardcoded` so any future changes will require contract re-deployment and re-registering to the EVE World.

Both examples provide access control for three account contexts:

- `tx.origin` access control logic which checks the original transaction sender
- `world.initialMsgSender()` access control logic which checks the initial EVE World interactor
- `_msgsender()` access control logic which checks the MUD `_msgSender()` context, which is the same as `msg.sender` in normal contract patterns

NOTE: currently both examples are __contracts only__ and include only the original MUD boilerplate front-end sample code (which is mismatched with the contract implementations, so the FE Dapp portion won't work as-is)