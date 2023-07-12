import { FunctionComponent } from "react";
import QRCode from 'qrcode.react';
import { Box } from "theme-ui";

interface CodeProps {
    value: string;
}

const Code: FunctionComponent<CodeProps> = (props) => {
  const { value } = props;
  return (
    <Box sx={{ width: [400] }}>
      <QRCode level={"L"} size={400} value={value} />
    </Box>
  );
};

export default Code;
