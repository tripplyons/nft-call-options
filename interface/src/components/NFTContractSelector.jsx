import { TextField, Typography, Stack } from "@mui/material";
import { erc721ABI, useAccount, useContractRead } from "wagmi";
import { shortenAddress } from "../helpers";

export default function NFTContractSelector({ address, setAddress, isValid }) {
  const account = useAccount();
  const safeAddress = isValid ? address : "0x" + "0".repeat(42);
  const balanceRead = useContractRead({
    addressOrName: safeAddress,
    contractInterface: erc721ABI,
    functionName: 'balanceOf',
    args: [account.address]
  });
  const balance = balanceRead.data;
  const nameRead = useContractRead({
    addressOrName: safeAddress,
    contractInterface: erc721ABI,
    functionName: 'name',
    args: []
  });
  const name = nameRead.data;

  return (
    <Stack spacing={2}>
      <TextField fullWidth value={address} onChange={(e) => {
        setAddress(e.target.value);
      }} label='NFT Contract Address' />
      {
        isValid ? (
          <>
            <Typography>
              <b>Collection Name:</b> {name ? name : `Not Found`}
              <br /><b>Your Balance:</b> {balance ? balance.toString() : `Not Found`}
              {
                (!balance || !name) ? (
                  <>
                    <br />Make sure that <b>{shortenAddress(address)}</b> it is an ERC721 NFT contract.
                  </>
                ) : null
              }
            </Typography>
          </>
        ) : (
          <Typography>
            Invalid Contract
          </Typography>
        )
      }
    </Stack>
  );
}
