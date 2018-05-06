// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { USER_CREATED_FAILURE,
         ACTIVE_OR_UPCOMING_USERS_FETCHED,
         USERS_FETCHED
       } from '../actions/types';
import _ from 'lodash';

const keyDate = (d) => {
  const date = new Date(d)
  const dateMonth = date.getMonth() + 1
  return new Date(Date.UTC(date.getFullYear(), dateMonth, 0)).toISOString().substring(0, 10)
}

export default function(state = {}, action) {
  switch(action.type) {
    case USER_CREATED_FAILURE:
      return { ...state, error: action.payload };
    case ACTIVE_OR_UPCOMING_USERS_FETCHED:
      return { ...state, active_or_upcoming_users: action.payload };
    case USERS_FETCHED:
      const users = _.mapKeys(action.payload, 'id')
      const byCheckInMonth = _.groupBy(action.payload, function(user) {
        return keyDate(user.check_in)
      });
      const byCheckOutMonth = _.groupBy(action.payload, function(user) {
        return keyDate(user.check_out)
      });
      return { ...state,
               byId: { ...state.byId, ...users },
               byCheckInMonth: { ...state.byCheckInMonth, ...byCheckInMonth },
               byCheckOutMonth: { ...state.byCheckOutMonth, ...byCheckOutMonth }
             }
  }

  return state
}

_.reduce({ 'a': 1, 'b': 2, 'c': 1 }, function(result, value, key) {
  (result[value] || (result[value] = [])).push(key);
  return result;
}, {});