import * as React from 'react';

import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import VgsShowAttribute from 'vgs-show-react-native';

export default function App() {
  const vgsShow = React.useRef<VgsShowAttribute>(null);
  const customerToken = 'TOKEN_HERE';
  const ENV = 'sandbox';
  const VAULT_ID = 'tntazhyknp1';

  return (
    <View style={styles.container}>
      <TouchableOpacity
        onPress={() => {
          if (vgsShow.current) {
            vgsShow.current
              .reveal(`/secure-data`, 'get', {})
              .then((code) => console.log('done', code))
              .catch((e) => console.error('fail', e));
          }
        }}
      >
        <Text>Reveal</Text>
      </TouchableOpacity>
      <VgsShowAttribute
        ref={vgsShow}
        textColor={'#00ff00'}
        initParams={{
          environment: ENV,
          vaultId: VAULT_ID,
          customHeaders: {
            Authorization: 'Bearer ' + customerToken,
          },
        }}
        fontSize={12}
        borderColor={'transparent'}
        contentPath="data.attributes.pan"
        placeholder="Value will appear here"
        style={styles.box}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 200,
    height: 50,
    marginVertical: 20,
  },
});
