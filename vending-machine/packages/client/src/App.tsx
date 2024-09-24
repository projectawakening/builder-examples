import { useMUD } from "./MUDContext";

const styleUnset = { all: "unset" } as const;

export const App = () => {
  const {
    network: { tables, useStore },
    systemCalls: { addTask, toggleTask, deleteTask },
  } = useMUD();

  const tasks = useStore((state) => {
    const records = Object.values(state.getRecords(tables.Tasks));
    records.sort((a, b) => Number(a.value.createdAt - b.value.createdAt));
    return records;
  });

  return (
    <>
    </>
  );
};
