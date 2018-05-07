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
  note() {
    return (this.props.amount > 0) &&
                <p className="ml-1 card-text d-inline-block"><small className="text-muted">Prélevé le <Moment locale='fr' format='DD MMMM' utc>{formatFromNowDates(this.props.fromNow)[1]}</Moment></small></p>

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
      return <span className='badge badge-warning text-right'>✈️ Départs</span>
    } else {
      return <span className='badge badge-success text-right'>✅ Arrivées</span>
    }
  }

  renderUsers(type, user, users) {
    if (_.isEmpty(users)) return ''
    return (
      <div>
        <h6 className="mt-0 mb-1">
          {this.badge(type, user.check_out)}
        </h6>
        <div className='my-2 d-flex flex-row align-items-start'>
          {users.map((user, index) =>
            <div className='mr-2 text-truncate'>
              <Avatar className='d-block' user={user} xs circle/>
              <small><FriendlyName firstname={user.firstname} lastname={user.lastname} /></small>
              <br/>
              <small>
                <Moment locale="fr" format='DD/MM'>
                  {user[type]}
                </Moment>
              </small>
            </div>
          )}
        </div>
      </div>
    )
  }
  render() {
    const { user, check_ins, check_outs, amounts } = this.props;

    return (
      <Card className='mb-2 border'
            title={
              <h3><Moment locale='fr' format='MMMM' utc>{formatFromNowDates(this.props.fromNow)[1]}</Moment></h3>
            }
            footer={
              <div>
                <h3 className='d-inline-block'>{this.description()}</h3>{this.note()}
              </div>
            }
            >
              {_.isEmpty(check_outs) && _.isEmpty(check_ins) &&
                <p className='text-center'><h2 style={{'font-size': '3rem'}}>🐰</h2><h4>Quoi de neuf docteur ?</h4></p>
              }
              {this.renderUsers('check_out', user, check_outs)}
              {this.renderUsers('check_in', user, check_ins)}
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