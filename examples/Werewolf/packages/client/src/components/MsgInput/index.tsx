import React, { useCallback, useState } from "react";
import {
  ChatAutoComplete,
  useChatContext,
} from "@web3mq/react-components";
import cx from "classnames";

import ss from "./index.module.css";


const MsgInput: React.FC = () => {
  const [visible, setVisible] = useState<boolean>(false);
  const { appType } = useChatContext("MsgInput");

  return (
    <>
      <div className={cx(ss.inputBox, { [ss.mobileStyle]: appType === "h5" })}>
        <ChatAutoComplete />
      </div>
    </>
  );
};

export default MsgInput;
