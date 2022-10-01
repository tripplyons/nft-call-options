import { Card, Stack } from "@mui/material";
import { useState } from "react";
import NFTContractSelector from "./NFTContractSelector";
import { useProvider } from "wagmi";
import { Container } from "@mui/system";
import { isValidContract } from "../helpers";
import { useEffect } from "react";

export default function SellInterface() {
  const provider = useProvider()
  const [contract, setContract] = useState("");
  const [contractIsValid, setContractIsValid] = useState(false);

  useEffect(() => {
    (async () => {
      setContractIsValid(await isValidContract(provider, contract));
    })();
  }, [contract])

  return (
    <Card>
      <Container sx={{ p: 4 }}>
        <Stack spacing={4}>
          <NFTContractSelector address={contract} setAddress={async (address) => {
            setContract(address);
          }} isValid={contractIsValid} />
        </Stack>
      </Container>
    </Card>
  );
}
