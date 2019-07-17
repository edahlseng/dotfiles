// Add any auto-loaded Atom code on init here.

function consumeVimModePlusService(callback) {
  const consume = (pack) => callback(pack.mainModule.provideVimModePlus())

  const pack = atom.packages.getActivePackage('vim-mode-plus')
  if (pack) {
    consume(pack)
  } else {
    const disposable = atom.packages.onDidActivatePackage(pack => {
      if (pack.name === 'vim-mode-plus') {
        disposable.dispose()
        consume(pack)
      }
    })
  }
}


consumeVimModePlusService(service => {
  class DeleteWithBlackholeRegister extends service.getClass("Delete") {
    execute() {
      this.vimState.register.name = "_"
      super.execute()
    }
  }
  DeleteWithBlackholeRegister.commandPrefix = "vim-mode-plus-user"
  DeleteWithBlackholeRegister.registerCommand()
})
