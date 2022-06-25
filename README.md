# Diagnostic Window

Shows the diagnostic messages for the given line in a split window. This was
created to help decipher very long typescript messages that don't fit nicely into 
a floating window or virtual text.

This also adds custom syntax highlighting for the diagnostic message. the current 
version was designed specifically for typescript errors.

![diagnostic-window-typescript-example](https://user-images.githubusercontent.com/5160605/175788492-320fb6e7-a11d-4b16-9083-acb50f3e1d30.png)


## Quickstart

Clone the repository using your favorite plugin manager. For example, with packer:
```lua
  use { "cseickel/diagnostic-window.nvim/" }

```

Then open the window with this command:
```
:DiagWindowShow
```

## License

MIT

## Contributing

Please do!
