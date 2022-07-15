import { ConnectButton } from '@rainbow-me/rainbowkit';
import useSSRCheck from '../hooks/useSRRCheck';

export default function CustomConnectButton({ Button }) {
  const { isSSR } = useSSRCheck();

  if(isSSR) {
    return null;
  }

  return (
    <span>
      <ConnectButton.Custom>
        {({
          account,
          chain,
          openAccountModal,
          openChainModal,
          openConnectModal,
          mounted,
        }) => {
          return (
            <div
              {...(!mounted && {
                'aria-hidden': true,
                'style': {
                  opacity: 0,
                  pointerEvents: 'none',
                  userSelect: 'none',
                },
              })}
            >
              {(() => {
                if (!mounted || !account || !chain) {
                  return (
                    <Button onClick={openConnectModal}>
                      Connect Wallet
                    </Button>
                  );
                }
  
                if (chain.unsupported) {
                  return (
                    <Button onClick={openChainModal}>
                      Wrong network
                    </Button>
                  );
                }
  
                return (
                  <div style={{ display: 'flex', gap: 12 }}>
                    <Button
                      onClick={openChainModal}
                    >
                      {chain.hasIcon && (
                        <div
                          style={{
                            marginRight: 4,
                          }}
                        >
                          {chain.iconUrl && (
                            <img
                              alt={chain.name ?? 'Chain icon'}
                              src={chain.iconUrl}
                              style={{ width: 12, height: 12 }}
                            />
                          )}
                        </div>
                      )}
                      {chain.name}
                    </Button>
  
                    <Button onClick={openAccountModal} type="button">
                      {account.displayName}
                      {account.displayBalance
                        ? ` (${account.displayBalance})`
                        : ''}
                    </Button>
                  </div>
                );
              })()}
            </div>
          );
        }}
      </ConnectButton.Custom>
    </span>
  );
}