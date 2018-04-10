// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import {
         MESSAGES_FETCHED,
         MESSAGE_LIKED
       } from '../actions/types';
import _ from 'lodash';

export default function(state = {byId: {}, allIds: {}, byUserId: {}}, action, props) {
  switch(action.type) {
    case MESSAGES_FETCHED:
      const messages = _.mapKeys(action.payload, 'id')
      const byUserId = _.reduce(messages, function(result, message, id) {
        (result[message.user_id] || (result[message.user_id] = [])).push(id);
        return result;
      }, {});
      return { ...state,
               byId: { ...state.byId, ...messages },
               allIds: [...state.allIds, ..._.map(action.payload, p => { return p.id })],
               byUserId: { ...state.byUserId, ...byUserId }
             }
    case MESSAGE_LIKED:
      return { ...state,
               byId: { ...state.byId, [action.payload.id]: action.payload }
             }
  }
  return state;
}