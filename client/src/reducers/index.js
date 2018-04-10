import { combineReducers } from 'redux';
import sessionsReducer from './sessions_reducer';
import housesReducer from './houses_reducer';
import balancesReducer from './balances_reducer';
import usersReducer from './users_reducer';
import messagesReducer from './messages_reducer';
import { reducer as formReducer } from 'redux-form';

const rootReducer = combineReducers({
  houses: housesReducer,
  session: sessionsReducer,
  form: formReducer,
  balance: balancesReducer,
  messages: messagesReducer,
  user: usersReducer
});

export default rootReducer;
