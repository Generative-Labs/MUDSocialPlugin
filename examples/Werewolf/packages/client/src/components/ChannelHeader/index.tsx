import React, { useState } from "react";
import {
  useChatContext,
} from "@web3mq/react-components";

import ss from "./index.module.css";
import {ChannelHeaderIcon} from "../../icons";

const ChannelHeader: React.FC = () => {

  return (
      <div className={ss.headerBox}>
            <ChannelHeaderIcon style={{ marginRight: '16px' }} />
            <div>
                Werewolf
            </div>
      </div>
  );
};

export default ChannelHeader;
