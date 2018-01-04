import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import ReduxPromise from 'redux-promise';
import ReduxThunk from 'redux-thunk';

import Home from './components/home';
import SessionsNew from './components/sessions_new';
import requireSession from './components/hoc/require_session';
import noSession from './components/hoc/no_session';
import Secret from './components/secret';

import reducers from './reducers';

import registerServiceWorker from './registerServiceWorker';

import { SESSION_CREATED } from './actions/types';

const createStoreWithMiddleware = applyMiddleware(ReduxPromise, ReduxThunk)(createStore);
const store = createStoreWithMiddleware(reducers);
const token = localStorage.getItem('token');

if(token) {
  store.dispatch({ type: SESSION_CREATED, payload:  JSON.parse(localStorage.getItem('user')) });
}

ReactDOM.render(
  <Provider store={store}>
    <BrowserRouter>
     <div>
        <Switch>
{/*          <Route path="/posts/new" component={PostsNew} />
          <Route path="/posts/:id" component={PostsShow} />*/}
          <Route path="/sessions/new" component={SessionsNew} />
          <Route path="/secret" component={requireSession(Secret)} />
          <Route path="/" component={noSession(Home)} />
        </Switch>
      </div>
    </BrowserRouter>
  </Provider>
  , document.getElementById('root'));
registerServiceWorker();