import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import ReduxPromise from 'redux-promise';
import ReduxThunk from 'redux-thunk';

import Home from './components/home';
import SessionsNew from './components/sessions_new';
import SessionsProvider from './components/sessions_provider';
import requireSession from './components/hoc/require_session';
import noSession from './components/hoc/no_session';
import Dashboard from './components/dashboard';
import DashboardHouse from './components/dashboard_house';
import NavBar from './components/navbar';
import Widgets from './containers/widgets';

import reducers from './reducers';

import registerServiceWorker, { unregister } from './registerServiceWorker';

import { SESSION_CREATED } from './actions/types';

import './index.css';
import './toolkit.min.css';

const createStoreWithMiddleware = applyMiddleware(ReduxPromise, ReduxThunk)(createStore);
const store = createStoreWithMiddleware(reducers);

// https://github.com/facebook/create-react-app/issues/1910
unregister() ;

ReactDOM.render(
  <Provider store={store}>
    <BrowserRouter>
     <div>
        <NavBar />
        <Widgets />
        <Switch>
          <Route path="/sessions/new" component={SessionsNew} />
          <Route path="/sessions/:provider" component={SessionsProvider} />
          <Route path="/dashboard/house" component={requireSession(DashboardHouse)} />
          <Route path="/dashboard" component={requireSession(Dashboard)} />
          <Route path="/" component={noSession(Home)} />
        </Switch>
      </div>
    </BrowserRouter>
  </Provider>
, document.getElementById('root'));