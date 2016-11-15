/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import guru.mmp.common.util.DateUtil;

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResponse</code> class implements the Survey Response entity, which represents
 * a user's response to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESPONSES")
@Access(AccessType.FIELD)
@Vetoed
public class SurveyResponse
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  @Id
  @Column(name = "ID", nullable = false)
  @JsonProperty
  private UUID id;

  /**
   * The survey instance this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  @JsonIgnore
  private SurveyInstance instance;

  /**
   * The optional survey request this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_REQUEST_ID")
  @JsonIgnore
  private SurveyRequest request;

  /**
   * The survey group rating item responses that are associated with the survey response.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupRatingItemResponse> groupRatingItemResponses;

  /**
   * The date and time the survey response was received.
   */
  @Column(name = "RESPONDED", nullable = false)
  @JsonIgnore
  private Date responded;

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyResponse() {}

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param instance the survey instance this survey response is associated with
   */
  public SurveyResponse(SurveyInstance instance)
  {
    this(instance, null);
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param instance the survey instance this survey response is associated with
   * @param request  the optional survey request this survey response is associated with
   */
  public SurveyResponse(SurveyInstance instance, SurveyRequest request)
  {
    this(UUID.randomUUID(), instance, request);
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param id       the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                 response
   * @param instance the survey instance this survey response is associated with
   */
  public SurveyResponse(UUID id, SurveyInstance instance)
  {
    this(id, instance, null);
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param id       the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                 response
   * @param instance the survey instance this survey response is associated with
   * @param request  the optional survey request this survey response is associated with
   */
  public SurveyResponse(UUID id, SurveyInstance instance, SurveyRequest request)
  {
    this.id = id;
    this.instance = instance;
    this.request = request;
    this.responded = new Date();
    this.groupRatingItemResponses = new ArrayList<>();

    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition : instance.getDefinition()
        .getGroupRatingItemDefinitions())
    {
      SurveyGroupDefinition groupDefinition = instance.getDefinition().getGroupDefinition(
        groupRatingItemDefinition.getGroupDefinitionId());

      for (SurveyGroupMemberDefinition groupMemberDefinition : groupDefinition.getGroupMemberDefinitions())
      {
        groupRatingItemResponses.add(
          new SurveyGroupRatingItemResponse(groupRatingItemDefinition, groupMemberDefinition));
      }
    }
  }

  /**
   * Indicates whether some other object is "equal to" this one.
   *
   * @param obj the reference object with which to compare
   *
   * @return <code>true</code> if this object is the same as the obj argument otherwise
   *         <code>false</code>
   */
  @Override
  public boolean equals(Object obj)
  {
    if (this == obj)
    {
      return true;
    }

    if (obj == null)
    {
      return false;
    }

    if (getClass() != obj.getClass())
    {
      return false;
    }

    SurveyResponse other = (SurveyResponse) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the JSON data for the survey response.
   *
   * @return the JSON data for the survey response
   */
  @Column(name = "DATA", nullable = false)
  @Access(AccessType.PROPERTY)
  @JsonIgnore
  public String getData()
  {
    try
    {
      return new ObjectMapper().writeValueAsString(this);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to generate the JSON data for the survey response", e);
    }
  }

  /**
   * Retrieve the survey group rating item response.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating item response
   *
   * @return the survey group rating item response or <code>null</code> if the survey group rating
   *         item response could not be found
   */
  public SurveyGroupRatingItemResponse getGroupRatingItemResponse(UUID id)
  {
    for (SurveyGroupRatingItemResponse groupRatingItemResponse : groupRatingItemResponses)
    {
      if (groupRatingItemResponse.getId().equals(id))
      {
        return groupRatingItemResponse;
      }
    }

    return null;
  }

  /**
   * Retrieve the survey group rating item response.
   *
   * @param groupRatingItemDefinitionId the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group rating item definition this survey
   *                                    group rating item response is associated with
   * @param groupMemberDefinitionId     the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group member definition this survey
   *                                    group rating item response is associated with
   *
   * @return the survey group rating item response or <code>null</code> if the survey group rating
   *         item response could not be found
   */
  public SurveyGroupRatingItemResponse getGroupRatingItemResponse(UUID groupRatingItemDefinitionId,
      UUID groupMemberDefinitionId)
  {
    for (SurveyGroupRatingItemResponse groupRatingItemResponse : groupRatingItemResponses)
    {
      if ((groupRatingItemResponse.getGroupRatingItemDefinitionId().equals(
          groupRatingItemDefinitionId))
          && (groupRatingItemResponse.getGroupMemberDefinitionId().equals(groupMemberDefinitionId)))
      {
        return groupRatingItemResponse;
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating item responses that are associated with the survey response.
   *
   * @return the survey group rating item responses that are associated with the survey response
   */
  public List<SurveyGroupRatingItemResponse> getGroupRatingItemResponses()
  {
    return groupRatingItemResponses;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the survey instance this survey response is associated with.
   *
   * @return the survey instance this survey response is associated with
   */
  public SurveyInstance getInstance()
  {
    return instance;
  }

  /**
   * The name for the survey response.
   *
   * @return the name for the survey response
   */
  @JsonIgnore
  public String getName()
  {
    if (request == null)
    {
      return String.format("Anonymous on %s", DateUtil.getYYYYMMDDFormat().format(getResponded()));
    }
    else
    {
      return request.getFullName();
    }
  }

  /**
   * Returns the date and time the survey response was received.
   *
   * @return the date and time the survey response was received
   */
  public Date getResponded()
  {
    return responded;
  }

  /**
   * Returns the date and time the survey response was received as a <code>String</code>.
   *
   * @return the date and time the survey response was received as a <code>String</code>
   */
  @JsonIgnore
  public String getRespondedAsString()
  {
    return DateUtil.getYYYYMMDDWithTimeFormat().format(responded);
  }

  /**
   * Set the JSON data for the survey response.
   *
   * @param data the JSON data for the survey response
   */
  public void setData(String data)
  {
    try
    {
      new ObjectMapper().readerForUpdating(this).readValue(data);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to populate the survey response using the JSON data", e);
    }
  }

  /**
   * Set the date and time the survey response was received.
   *
   * @param responded the date and time the survey response was received
   */
  public void setResponded(Date responded)
  {
    this.responded = responded;
  }

  /**
   * Returns the String representation of the survey response.
   *
   * @return the String representation of the survey response
   */
  @Override
  public String toString()
  {
    return String.format("SurveyResponse {id=\"%s\", responded=\"%s\"}", getId(),
        DateUtil.getYYYYMMDDWithTimeFormat().format(getResponded()));
  }
}
