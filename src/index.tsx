import * as React from 'react';
import {
  requireNativeComponent,
  TextStyle,
  ViewStyle,
  findNodeHandle,
  NativeModules,
  Platform,
  UIManager,
  NativeSyntheticEvent,
} from 'react-native';

export type VgsShowReactNativeProps = {
  /** Style for the root parent element */
  style: ViewStyle;
  /**
   * Styles for the VGS Label
   */
  textColor?: TextStyle['color'];
  placeholderColor?: TextStyle['color'];
  bgColor?: TextStyle['color'];
  borderColor?: TextStyle['color'];
  fontSize?: TextStyle['fontSize'];
  fontFamily?: TextStyle['fontFamily'];
  characterSpacing?: number;
  borderRadius?: number;
  addSpaces?:boolean;
  /**
   * Placeholder while value is not available. Only for iOS.
   */
  placeholder?: string;

  contentPath: string;
  initParams: {
    vaultId: string;
    environment: 'live' | 'sandbox';
    customHeaders?: Record<string, any>;
  };
  format?: {
    pattern: string;
    template: string;
  };
};

const NATIVE_COMP_IDENTIFIER = 'VgsShowReactNativeView';

const VgsShowAttributeNative = requireNativeComponent<
  VgsShowReactNativeProps & {
    onReqDone: (
      event: NativeSyntheticEvent<{
        reqId: number;
        code: number;
        error?: string;
      }>
    ) => void;
  }
>(NATIVE_COMP_IDENTIFIER);

const promiseMap: Record<
  number,
  { resolve: (code: number) => void; reject: (e: Error) => void }
> = {};

let reqId = 0;

export class VgsShowAttribute extends React.Component<VgsShowReactNativeProps> {
  private _nativeRef: any;

  async reveal(
    path: string,
    method: 'get' | 'post',
    payload = {}
  ): Promise<number> {
    if (this._nativeRef) {
      const handle = findNodeHandle(this._nativeRef);

      const perform = Platform.select({
        ios: () => {
          return NativeModules.VgsShowReactNativeViewManager.revealData(
            handle,
            path,
            method,
            payload
          ) as Promise<number>;
        },
        android: () => {
          return new Promise((resolve, reject) => {
            reqId = reqId + 1;
            promiseMap[reqId] = { resolve, reject };

            UIManager.dispatchViewManagerCommand(handle, 'revealData' as any, [
              reqId,
              path,
              method,
              payload,
            ]);
          });
        },
      });

      return perform!() as any;
    }

    return Promise.reject('No ref available for native comp!');
  }

  copyToClipboard(): void {
    const handle = findNodeHandle(this._nativeRef);
    const copy = Platform.select({
      ios: () => {
        NativeModules.VgsShowReactNativeViewManager.copyToClipboard(handle);
      },
      android: () => {
        UIManager.dispatchViewManagerCommand(
          handle,
          'copyToClipboard' as any,
          []
        );
      },
    });
    copy?.();
  }

  render() {
    return (
      <VgsShowAttributeNative
        {...this.props}
        onReqDone={(event) => {
          // This one is used only for Android, to get the result code and wrap it
          // with a unified promise interface
          const { reqId: resultReqId, code, error } = event.nativeEvent;

          if (resultReqId && promiseMap[resultReqId]) {
            if (code > 0) {
              promiseMap[resultReqId].resolve(code);
            } else {
              promiseMap[resultReqId].reject(new Error(error));
            }

            delete promiseMap[resultReqId];
          }
        }}
        ref={(ref: any) => {
          this._nativeRef = ref;
        }}
      />
    );
  }
}

export default VgsShowAttribute;
