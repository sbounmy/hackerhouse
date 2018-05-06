// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { USER_CREATED_FAILURE,
         ACTIVE_OR_UPCOMING_USERS_FETCHED,
         USERS_FETCHED
       } from '../actions/types';
import _ from 'lodash';

export default function(state = {}, action) {
  switch(action.type) {
    case USER_CREATED_FAILURE:
      return { ...state, error: action.payload };
    case ACTIVE_OR_UPCOMING_USERS_FETCHED:
      return { ...state, active_or_upcoming_users: action.payload };
    case USERS_FETCHED:
      const users = _.mapKeys(action.payload, 'id')
      const byCheckMonth = _.groupBy(action.payload, function(user) {
        const active = new Date(user.check_in) < _.now()
        user.action = `check_${active ? 'out' : 'in'}`
        user.action_date = active ? user.check_out : user.check_in

        const date = new Date(user.action_date)
        const dateMonth = date.getMonth() + 1
        user.action_month = new Date(Date.UTC(date.getFullYear(), dateMonth, 0)).toISOString().substring(0, 10)
        return user.action_month
      });
      return { ...state,
               byId: { ...state.byId, ...users },
               byCheckMonth: { ...state.byCheckMonth, ...byCheckMonth },
             }
  }

  return state
}