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

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResult</code> class implements the Survey Result entity, which represents
 * the results of a survey compiled from the users responses' to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESULTS")
@Access(AccessType.FIELD)
@Vetoed
public class SurveyResult
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey result.
   */
  @Id
  @Column(name = "ID", nullable = false)
  @JsonProperty
  private UUID id;

  /**
   * The survey instance this survey result is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  @JsonIgnore
  private SurveyInstance instance;

  /**
   * The survey group rating item results that are associated with the survey result.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupRatingItemResult> groupRatingItemResults;

  /**
   * Constructs a new <code>SurveyResult</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyResult() {}

  /**
   * Constructs a new <code>SurveyResult</code>.
   *
   * @param instance the survey instance this survey result is associated with
   */
  public SurveyResult(SurveyInstance instance)
  {
    this(UUID.randomUUID(), instance);
  }

  /**
   * Constructs a new <code>SurveyResult</code>.
   *
   * @param id       the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                 result
   * @param instance the survey instance this survey result is associated with
   */
  public SurveyResult(UUID id, SurveyInstance instance)
  {
    this.id = id;
    this.instance = instance;

    this.groupRatingItemResults = new ArrayList<>();

    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition : instance.getDefinition()
        .getGroupRatingItemDefinitions())
    {
      SurveyGroupDefinition groupDefinition = instance.getDefinition().getGroupDefinition(
        groupRatingItemDefinition.getGroupDefinitionId());

      for (SurveyGroupMemberDefinition groupMemberDefinition :
        groupDefinition.getGroupMemberDefinitions())
      {
        groupRatingItemResults.add(new SurveyGroupRatingItemResult(groupRatingItemDefinition,
          groupMemberDefinition));
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

    SurveyResult other = (SurveyResult) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the JSON data for the survey result.
   *
   * @return the JSON data for the survey result
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
      throw new RuntimeException("Failed to generate the JSON data for the survey result", e);
    }
  }

  /**
   * Retrieve the survey group rating item result.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating item result
   *
   * @return the survey group rating item result or <code>null</code> if the survey group rating
   *         item result could not be found
   */
  public SurveyGroupRatingItemResult getGroupRatingItemResult(UUID id)
  {
    for (SurveyGroupRatingItemResult groupRatingItemResult : groupRatingItemResults)
    {
      if (groupRatingItemResult.getId().equals(id))
      {
        return groupRatingItemResult;
      }
    }

    return null;
  }

  /**
   * Retrieve the survey group rating item result.
   *
   * @param groupRatingItemDefinitionId the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group rating item definition this survey
   *                                    group rating item result is associated with
   * @param groupMemberDefinitionId     the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group member definition this survey
   *                                    group rating item result is associated with
   *
   * @return the survey group rating item result or <code>null</code> if the survey group rating
   *         item result could not be found
   */
  public SurveyGroupRatingItemResult getGroupRatingItemResult(UUID groupRatingItemDefinitionId,
      UUID groupMemberDefinitionId)
  {
    for (SurveyGroupRatingItemResult groupRatingItemResult : groupRatingItemResults)
    {
      if ((groupRatingItemResult.getGroupRatingItemDefinitionId().equals(
          groupRatingItemDefinitionId))
          && (groupRatingItemResult.getGroupMemberDefinitionId().equals(groupMemberDefinitionId)))
      {
        return groupRatingItemResult;
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating item results that are associated with the survey result.
   *
   * @return the survey group rating item results that are associated with the survey result
   */
  public List<SurveyGroupRatingItemResult> getGroupRatingItemResults()
  {
    return groupRatingItemResults;
  }

  /**
   * Returns the survey group rating item results that are associated with the survey group member
   * definition with the specified ID.
   *
   * @param groupMemberDefinitionId the Universally Unique Identifier (UUID) used to uniquely
   *                                identify the survey group member definition
   *
   * @return the survey group rating item results that are associated with the survey group member
   *         definition with the specified ID
   */
  public List<SurveyGroupRatingItemResult> getGroupRatingItemResultsForGroupMember(
      UUID groupMemberDefinitionId)
  {
    return groupRatingItemResults.stream().filter(
        surveyGroupRatingItemResult -> surveyGroupRatingItemResult.getGroupMemberDefinitionId()
        .equals(groupMemberDefinitionId)).collect(Collectors.toList());
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey result.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey result
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
   * Set the JSON data for the survey result.
   *
   * @param data the JSON data for the survey result
   */
  public void setData(String data)
  {
    try
    {
      new ObjectMapper().readerForUpdating(this).readValue(data);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to populate the survey result using the JSON data", e);
    }
  }

  /**
   * Returns the String representation of the survey result.
   *
   * @return the String representation of the survey result
   */
  @Override
  public String toString()
  {
    return String.format("SurveyResult {id=\"%s\"}", getId());
  }
}
