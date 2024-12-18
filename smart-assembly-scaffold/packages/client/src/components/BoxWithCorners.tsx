import { ReactNode } from "react";

import { ReactComponent as Corner } from "../assets/corner.svg";

export default function BoxWithCorners({
  children,
  style,
}: {
  children: ReactNode;
  style?: string;
}) {
  return (
    <div
      className={`self-stretch bg-crude-30 border border-orange-100/20 flex-col justify-start items-start gap-6 flex relative ${style}`}
      id="purchase-pack"
    >
      <Corner className="absolute rotate-90" />
      <Corner className="absolute rotate-180 right-0" />
      <Corner className="absolute bottom-0" />
      <Corner className="absolute rotate-[270deg] bottom-0 right-0 flip-horizontal" />

      {children}
    </div>
  );
}
