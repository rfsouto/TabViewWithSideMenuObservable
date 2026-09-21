import re,sys
p='TabViewWithSideMenuWithViewModel/Views/ContentView.swift'
s=open(p).read()
n,c=re.subn(r'TabView\(selection: Binding\(.*?\)\) \{\n(?:[ \t]*// Variante B[^\n]*\n[ \t]*// TabView[^\n]*\n)?','TabView(selection: $viewModel.option) {\n',s,count=1,flags=re.S)
assert c==1
open(p,'w').write(n)
