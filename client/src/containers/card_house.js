import React, { Component } from 'react';
import { connect } from 'react-redux';
import { fetchHouse } from '../actions';
import { Card } from '../components/bs';

class CardHouse extends Component {

  componentDidMount() {
    if (!this.props.house) {
      this.props.fetchHouse(this.props.user.house_slug_id);
    }
  }

  render() {
    const { house } = this.props;
    if (!house) {
      return ''
    }
    return (
      <Card className="d-md-block d-lg-block mb-4"
            title={<div>{house.name} <small>· <a href="#">RATP</a></small></div>}
            >
        <ul className="list-unstyled list-spaced">
          <li><span className="text-muted icon icon-home mr-3"></span>Lives in <a href="#">{house.address}</a></li>
          <li><span className="text-muted icon icon-location-pin mr-3"></span>From <a href="#">{house.zip_code} {house.city}</a></li>
          <li><span className="text-muted icon icon-users mr-3"></span>Hackers : <a href="#">{house.active_users} / {house.max_users}</a></li>
        </ul>
      </Card>
    )
  }
}


function mapStateToProps(state, nextProps) {
  return { user: state.session.user, house: state.houses[nextProps.id] };
}

export default connect(mapStateToProps, { fetchHouse })(CardHouse);