import React, { Component } from 'react';
import _ from 'lodash';

export default class Expandable extends Component {
  constructor(props) {
    super(props);
    this.state = {
      showAll: false
    }
    this.toggleShowAll = this.toggleShowAll.bind(this);
  }

  toggleShowAll(e){
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      showAll: !this.state.showAll
    })
  }
  toggleText() {
    return this.state.showAll ? 'Aucun autre message' : 'Voir tous les messages'
  }

  isHidden(index) {
    return ((index + 1 > this.props.show) && !this.state.showAll)
  }

  render() {
    const items = this.props.items || [];
    let displays = [];

    // need to be an array so we have an index https://lodash.com/docs#forEach
    _.each(_.values(items), (value, index) => {
      displays.push(this.props.children(value, this.isHidden(index)))
    });
    return (
      <ul className='list-unstyled'>
        {displays}
        <li>
          <p className="text-center">
            {<a href="#" onClick={this.toggleShowAll}>{this.toggleText()}</a>}
          </p>
        </li>
      </ul>
    )
  }
}