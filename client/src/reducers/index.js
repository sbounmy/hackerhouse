import { combineReducers } from 'redux';
import sessionsReducer from './sessions_reducer';
import housesReducer from './houses_reducer';
import { reducer as formReducer } from 'redux-form';

const rootReducer = combineReducers({
  houses: housesReducer,
  session: sessionsReducer,
  form: formReducer
});

export default rootReducer;
