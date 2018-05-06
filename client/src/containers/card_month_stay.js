import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Card, Button } from '../components/bs';
import { fetchBalance, fetchUsers } from '../actions';
import FriendlyName from '../components/friendly_name';
import Avatar from '../components/avatar'
import Moment, { moment } from 'react-moment';
import 'moment/locale/fr';
import _ from 'lodash';

const formatFromNowDates = (fromNow) => {
  const now = new Date()
  const nowMonth = now.getMonth()
  return [ new Date(Date.UTC(now.getFullYear(), nowMonth + fromNow, 1)),
           new Date(Date.UTC(now.getFullYear(), nowMonth + 1 + fromNow, 0)) ]
}

class CardStay extends Component {
  componentDidMount() {
    if (this.props.user && this.props.user.house_slug_id) {
      this.props.fetchBalance(
        this.props.user.house_slug_id,
        this.props.user.id,
        formatFromNowDates(this.props.fromNow)[1])
      this.props.fetchUsers({
        'q[house_id.eq]': this.props.user.house_id,
        'q[check]': [ formatFromNowDates(this.props.fromNow)[0].toISOString().substring(0, 10),
                      formatFromNowDates(this.props.fromNow)[1].toISOString().substring(0, 10) ]
      })
    }
  }

  description() {
    if (this.props.amount <= 0) {
      return "☀️ 0€"
    }
    else if (this.props.amount < 100) {
      return `😑 ${this.props.amount}€`
    }
    else if (this.props.amount > 100) {
      return `🚨 ${this.props.amount}€`
    }
  }

  badge(action, date) {
    if (action == 'check_out') {
      return <span className='badge badge-warning text-right'>✈️ Départ</span>
    } else {
      return <span className='badge badge-success text-right'>✅ Arrivée</span>
    }
  }

  render() {
    const { user, users, amounts } = this.props;

    return (
      <Card className='mb-2 border'
            title={
              <Moment locale='fr' format='MMMM' utc>{formatFromNowDates(this.props.fromNow)[1]}</Moment>
            }>
            <h3>{this.description()}</h3>
            <ul class="list-group list-group-flush">
              {users.map((user, index) =>
                <li className={`list-group-item`} key={index}>
                  <div className='d-flex flex-row justify-content-between align-items-start'>
                    <div>
                      <Avatar className='mx-2 d-block' user={user} xs circle/>
                      <small><FriendlyName firstname={user.firstname} lastname={user.lastname} /></small>
                    </div>
                    <div>
                      <h6 className="mt-0 mb-1">
                        {this.badge(user.action, user.action_date)}
                      </h6>
                      <Moment locale="fr" format='DD/MM'>
                          {user.action_date}
                      </Moment>
                    </div>
                  </div>
                </li>
              )}
            </ul>
      </Card>
    );
  }
}

function mapStateToProps(state, ownProps) {
  const date = formatFromNowDates(ownProps.fromNow)[1].toISOString().substring(0, 10)
  const amount = state.balance.amounts[date]
                && state.balance.amounts[date][state.session.user.id]
                && state.balance.amounts[date][state.session.user.id][1]
  // console.log(date, state.users.byCheckMonth[date])
  console.log(date, (state.users.byCheckMonth && state.users.byCheckMonth[date]) || [])
  return { user: state.session.user,
           amount: amount,
           users: (state.users.byCheckMonth && state.users.byCheckMonth[date]) || [] }
}

export default connect(mapStateToProps, { fetchBalance, fetchUsers })(CardStay);