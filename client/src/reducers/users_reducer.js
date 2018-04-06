// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { USER_CREATED_FAILURE,
         ACTIVE_OR_UPCOMING_USERS_FETCHED,
         USER_MESSAGES_FETCHED,
         USERS_FETCHED
       } from '../actions/types';
import _ from 'lodash';

export default function(state = {}, action) {
  switch(action.type) {
    case USER_CREATED_FAILURE:
      return { ...state, error: action.payload };
    case ACTIVE_OR_UPCOMING_USERS_FETCHED:
      return { ...state, active_or_upcoming_users: action.payload };
    case USER_MESSAGES_FETCHED:
      return { ...state, messages: action.payload };
    case USERS_FETCHED:
      return _.mapKeys(action.payload, 'id');
  }
  return state;
}