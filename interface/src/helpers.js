export async function isValidContract(provider, address) {
  if(!provider) {
    return false;
  }
  if (address.match(/^0x[0-9a-fA-F]*$/) && address.length === 42) {
    const codeLength = (await provider.getCode(address)).length;
    // codeLength === 2 would be "0x"
    return codeLength > 2;
  }
  return false;
};

export function shortenAddress(address) {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}
