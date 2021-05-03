# vgs-show-react-native

A react-native wrapper for VGS Show for displaying secure information using a proxy.

## Installation

```sh
npm install vgs-show-react-native
```

## Usage

```tsx
import VgsShowAttribute from 'vgs-show-react-native';

// ...

const vgsShow = React.useRef<VgsShowAttribute> = null;

<VgsShowAttribute
  ref={vgsShow}
  initParams={{
    environment: ENV,
    vaultId: VAULT_ID,
    // optional, if needed for the upstream service
    customHeaders: {
      Authorization: 'Bearer ' + customerToken,
    },
  }}
  contentPath="data.attributes.pan"
  placeholder="Value will appear here"
  style={styles.box}
/>;

// To trigger reveal:
<Button onPress={vgsShow.current?.reveal(PATH, METHOD, CUSTOM_PAYLOAD)}>
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
