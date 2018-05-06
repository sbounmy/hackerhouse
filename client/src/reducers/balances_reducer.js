// State argument is not application state, only the state
// this reducer is responsible for
// Never manipulate state. always return a new object/array
import { BALANCE_FETCHED } from '../actions/types';
import _ from 'lodash';

export default function(state = {}, action) {
  switch(action.type) {
    case BALANCE_FETCHED:
      // Map balance array to user ids
      // Transforms
      // [ [ {_id: "596cbc5af1805b000401e3ea", active: true, admin: false, avatar_url: "https://media.licdn.com/mpr/mprx/0_xrDWFXkqOLidCle…-PE8mdpVUy6r0kqw-Po8mzPSUyw5XZNOHGi8JkVS0uE7yPdDy", bio_title: "Assistant chef de campagne Digital et CRM chez Natixis  ;          ↵Freelance Web-Marketing/Growth", …},
      // 41], ...
      // ]
      // To :
      // {596cbc5af1805b000401e3ea: {_id: "596cbc5af1805b000401e3ea", active: true, admin: false, avatar_url: "https://media.licdn.com/mpr/mprx/0_xrDWFXkqOLidCle…-PE8mdpVUy6r0kqw-Po8mzPSUyw5XZNOHGi8JkVS0uE7yPdDy", bio_title: "Assistant chef de campagne Digital et CRM chez Natixis  ;          ↵Freelance Web-Marketing/Growth", …},
      // 41] }
      // const balances = _.mapKeys(data.users, function(value, key){ return value[0]._id });
      const balances = _.mapKeys(action.payload.users, function(value, key) { return value[0]._id });
      return { ...state, amounts: { ...state.amounts, [action.payload.date]: balances } };
  }
  return {amounts: {}, ...state};
}