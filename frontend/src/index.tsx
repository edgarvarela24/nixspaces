import { render } from 'solid-js/web';
import { Component } from 'solid-js';

const App: Component = () => {
  return (
    <div>
      <h1>NixSpaces</h1>
      <p>Branch Everything - Development Environment Platform</p>
    </div>
  );
};

const root = document.getElementById('root');

if (root) {
  render(() => <App />, root);
}