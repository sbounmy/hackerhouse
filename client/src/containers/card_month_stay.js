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
    const { user, check_ins, check_outs, amounts } = this.props;

    return (
      <Card className='mb-2 border'
            title={
              <Moment locale='fr' format='MMMM' utc>{formatFromNowDates(this.props.fromNow)[1]}</Moment>
            }>
            <h3>{this.description()}</h3>
            <ul class="list-group list-group-flush">
              {check_outs.map((user, index) =>
                <li className={`list-group-item`} key={index}>
                  <div className='d-flex flex-row justify-content-between align-items-start'>
                    <div>
                      <Avatar className='d-block' user={user} xs circle/>
                      <small><FriendlyName firstname={user.firstname} lastname={user.lastname} /></small>
                    </div>
                    <div className='text-right'>
                      <h6 className="mt-0 mb-1">
                        {this.badge('check_out', user.check_out)}
                      </h6>
                      <Moment locale="fr" format='DD/MM'>
                          {user.check_out}
                      </Moment>
                    </div>
                  </div>
                </li>
              )}
              {check_ins.map((user, index) =>
                <li className={`list-group-item`} key={index}>
                  <div className='d-flex flex-row justify-content-between align-items-start'>
                    <div>
                      <Avatar className='d-block' user={user} xs circle/>
                      <small><FriendlyName firstname={user.firstname} lastname={user.lastname} /></small>
                    </div>
                    <div className='text-right'>
                      <h6 className="mt-0 mb-1">
                        {this.badge('check_in', user.check_in)}
                      </h6>
                      <Moment locale="fr" format='DD/MM'>
                          {user.check_in}
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

  return { user: state.session.user,
           amount: amount,
           check_outs: (state.users.byCheckOutMonth && state.users.byCheckOutMonth[date]) || [],
           check_ins: (state.users.byCheckInMonth && state.users.byCheckInMonth[date]) || [] }
}

export default connect(mapStateToProps, { fetchBalance, fetchUsers })(CardStay);